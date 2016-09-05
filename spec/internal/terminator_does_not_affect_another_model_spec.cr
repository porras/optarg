require "../spec_helper"

module OptargTerminatorDoesNotAffectAnotherModelFeature
  class Terminated < Optarg::Model
    terminator "--"
  end

  class NotTerminated < Optarg::Model
  end

  it name do
    expect_raises(Optarg::UnknownOption) { NotTerminated.parse(%w(--)) }
  end
end
