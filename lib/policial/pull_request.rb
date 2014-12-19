module Policial
  # Public: A GibHub Pull Request.
  class PullRequest
    def initialize(payload = nil)
      @payload = payload
    end

    def comments
      @comments ||= api.pull_request_comments(full_repo_name, number)
    end

    def files
      @files ||= api.pull_request_files(full_repo_name, number).map do |file|
        build_commit_file(file)
      end
    end

    def comment_on_violation(violation)
      api.add_pull_request_comment(
        pull_request_number: number,
        comment: violation.messages.join('<br>'),
        commit: head_commit,
        filename: violation.filename,
        patch_position: violation.patch_position
      )
    end

    def repository_owner
      @payload.repository_owner
    end

    def opened?
      @payload.action == 'opened'
    end

    def synchronize?
      @payload.action == 'synchronize'
    end

    def head_commit
      @head_commit ||= Commit.new(full_repo_name, @payload.head_sha, api)
    end

    def number
      @payload.pull_request_number
    end

    def full_repo_name
      @payload.full_repo_name
    end

    private

    def build_commit_file(file)
      CommitFile.new(file, head_commit)
    end

    def api
      @api ||= Policial::GithubApi.new
    end
  end
end
