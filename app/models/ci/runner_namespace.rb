module Ci
  class RunnerNamespace < ActiveRecord::Base
    extend Gitlab::Ci::Model

    belongs_to :runner, inverse_of: :runner_namespaces, validate: true
    belongs_to :namespace, inverse_of: :runner_namespaces, class_name: '::Namespace'
    belongs_to :group, class_name: '::Group', foreign_key: :namespace_id
  end
end
