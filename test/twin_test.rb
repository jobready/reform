require 'test_helper'

require 'test_helper'
require 'reform_126/twin'

class TwinTest < MiniTest::Spec
  class SongForm < Reform126::Form
    class Twin < Disposable009::Twin
      property :title
      option :is_online # TODO: this should make it read-only in reform!
    end

    include Reform126::Twin
    twin Twin
  end

  let (:model) { OpenStruct.new(title: "Kenny") }

  let (:form) { SongForm.new(model, is_online: true) }

  it { form.title.must_equal "Kenny" }
  it { form.is_online.must_equal true }
end
