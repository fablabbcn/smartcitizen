require 'rails_helper'

RSpec.describe Storer, type: :model do

	before(:all) do
    create(:kit, id: 3, name: 'SCK', description: "Board", slug: 'sck', sensor_map: '{"temp": 12}')
    create(:sensor, id:12, name:'HPP828E031', description: 'test')
    create(:component, id: 12, board: Kit.find(3), sensor: Sensor.find(12), equation: '(175.72 / 65536.0 * x) - 53', reverse_equation: 'x')
  end

  after(:all) do
    DatabaseCleaner.clean_with(:truncation)
  end

	let(:device) { create(:device, device_token: 'aA1234', kit: Kit.find(3)) }

	let(:data) {
		{
			'recorded_at'=> '2016-06-08 10:30:00',
			'sensors'=> [{ 'id'=>12, 'value'=>21 }]
		}
	}

	let(:bad_data) {
		{
			'recorded_at'=> 'not time info here',
			'sensors'=> [{ 'id'=>12, 'value'=>21 }]
		}
	}

	let(:karios_data_array) { [{
		name: device.find_sensor_key_by_id(12),
		timestamp: Time.parse(data['recorded_at']).to_i * 1000,
		value: Component.first.normalized_value((Float(data['sensors'][0]['value']))),
		tags: {
			device_id: device.id,
			method: 'REST'
		}
	}] }

	let(:redis_json) {
		{
			device_id: device.id,
			device: JSON.parse(device.to_json(only: [:id, :name, :location])),
			timestamp: Time.parse(data['recorded_at']).to_i * 1000,
			readings: {"temp"=>[12, 21.0, -52.943693237304686]},
			stored: true,
			data: JSON.parse(ActionController::Base.new.view_context.render( partial: "v0/devices/device", locals: {device: device, current_user: nil}))
		}.to_json
	}

	before do
		allow(Rails.env).to receive(:production?).and_return(true)
		allow(Kairos).to receive(:http_post_to).with("/datapoints", anything)

		# ensuring hash keys sorting matches between expectations and results
		allow_any_instance_of(Device).to receive(:to_json).and_return(device.to_json(only: [:id, :name, :location]))

		view = ActionController::Base.new.view_context
		allow_any_instance_of(ActionController::Base).to receive(:view_context).and_return(view)
		allow(view).to receive(:render).and_return(ActionController::Base.new.view_context.render( partial: "v0/devices/device", locals: {device: device, current_user: nil}))
	end

	context 'when receiving good data' do
		after do
			Storer.new(device.id, data)
		end
		it 'stores data to karios db' do
			expect(Kairos).to receive(:http_post_to).with("/datapoints", karios_data_array)
		end
		it 'redis publish' do
			expect(Redis.current).to receive(:publish).with('data-received', redis_json)
		end
	end

	context 'when receiveng bad data' do
		it 'does redis publish anyway and raise error' do
			expect(Kairos).not_to receive(:http_post_to).with("/datapoints", anything)
			expect(Redis.current).to receive(:publish).with('data-received', anything)

			expect{ Storer.new(device.id, bad_data) }.to raise_error(ArgumentError)
		end
	end
end
