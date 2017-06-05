module Wolfman
  describe CircleCI do
    describe ".configured?" do
      subject { described_class.configured? }

      context "with missing configuration" do
        it { is_expected.to be(false) }
      end

      context "with valid configuration" do
        before do
          Config.save!(:circleci, {api_token: "some-token", username: "my-github-org"})
        end

        it { is_expected.to be(true) }
      end
    end
  end
end
