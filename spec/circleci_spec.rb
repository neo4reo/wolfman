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

    describe ".check_auth!" do
      before { set_valid_config! }

      context "authenticated" do
        before { stub_circleci_response(CircleCi::User, :me, status: 200) }

        it "returns true without raising an error" do
          expect(described_class.check_auth!).to be(true)
        end
      end

      context "unauthenticated" do
        before { stub_circleci_response(CircleCi::User, :me, status: 401) }

        it "raises a CircleCIError" do
          expect { described_class.check_auth! }.to raise_error(described_class::CircleCIError, /Unable to connect/)
        end
      end
    end

    describe ".recent_builds!" do
      before { set_valid_config! }
      let(:reponame) { "myproject" }
      let(:branch) { "master" }

      context "with valid reponame" do
        let(:body) { [{build_num: "123"}, {build_num: "345"}] }
        before { stub_circleci_response(CircleCi::Project, :recent_builds_branch, status: 200, body: body) }

        it "returns builds" do
          builds = described_class.recent_builds!(reponame, branch)
          expect(builds.map(&:build_num)).to eq(["123", "345"])
        end
      end

      context "reponame not found" do
        before { stub_circleci_response(CircleCi::Project, :recent_builds_branch, status: 404) }

        it "raises a CircleCIError" do
          expect { described_class.recent_builds!(reponame, branch) }.to raise_error(described_class::CircleCIError, /not found/)
        end
      end

      context "unauthenticated" do
        before { stub_circleci_response(CircleCi::Project, :recent_builds_branch, status: 401) }

        it "raises a CircleCIError" do
          expect { described_class.recent_builds!(reponame, branch) }.to raise_error(described_class::CircleCIError, /Unable to connect/)
        end
      end
    end
  end
end
