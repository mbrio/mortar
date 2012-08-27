require "spec_helper"
require "mortar/command/base"

module Mortar::Command
  describe Base do
    before do
      @base = Base.new
      stub(@base).display
      @client = Object.new
      stub(@client).host {'mortar.com'}
    end

    context "detecting the project" do
      it "read remotes from git config" do
        stub(Dir).chdir
        stub(@base.git).has_dot_git? {true}
        mock(@base.git).git("remote -v").returns(<<-REMOTES)
staging\tgit@github.com:mortarcode/4dbbd83cae8d5bf8a4000000_myproject-staging.git (fetch)
staging\tgit@github.com:mortarcode/4dbbd83cae8d5bf8a4000000_myproject-staging.git (push)
production\tgit@github.com:mortarcode/4dbbd83cae8d5bf8a4000000_myproject.git (fetch)
production\tgit@github.com:mortarcode/4dbbd83cae8d5bf8a4000000_myproject.git (push)
other\tgit@github.com:other.git (fetch)
other\tgit@github.com:other.git (push)
        REMOTES

        @mortar = Object.new
        stub(@mortar).host {'mortar.com'}
        stub(@base).mortar { @mortar }

        # need a better way to test internal functionality
        @base.git.send(:remotes, 'mortarcode').should == { 'staging' => 'myproject-staging', 'production' => 'myproject' }
      end

      it "gets the project from remotes when there's only one project" do
        stub(@base.git).has_dot_git? {true}
        stub(@base.git).remotes {{ 'mortar' => 'myproject' }}
        mock(@base.git).git("config mortar.remote", false).returns("")
        @base.project.name.should == 'myproject'
      end

      it "accepts a --remote argument to choose the project from the remote name" do
        stub(@base.git).has_dot_git?.returns(true)
        stub(@base.git).remotes.returns({ 'staging' => 'myproject-staging', 'production' => 'myproject' })
        stub(@base).options.returns(:remote => "staging")
        @base.project.name.should == 'myproject-staging'
      end

      it "raises when cannot determine which project is it" do
        stub(@base).git_remotes {{ 'staging' => 'myproject-staging', 'production' => 'myproject' }}
        lambda { @base.project }.should raise_error(Mortar::Command::CommandFailed)
      end
    end

  end
end
