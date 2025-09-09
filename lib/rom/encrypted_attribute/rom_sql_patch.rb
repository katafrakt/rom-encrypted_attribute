# frozen_string_literal: true

# this is used to silence the redefinition warnings
require "warning"

# This provides a patch for rom-sql while https://github.com/rom-rb/rom-sql/pull/432
# is pending merge. It allows to block reading unencrypted values from the database.
# You need to opt-in for this patch yourself by calling:
#
#     ROM::SQL::Patch432.install!
#
# The patch can be reverted with
#     ROM::SQL::Patch432.uninstall!
#
# Note: that you don't need this if you are using PostgreSQL.
# Also note that this will emit a warning of overwriting a method.
module ROM
  module SQL
    module Patch432
      def self.install!
        Warning.ignore(:method_redefined)
        ROM::SQL::Commands::Create.class_eval do
          def insert(tuples)
            pks = tuples.map { |tuple| relation.insert(tuple) }
            relation.dataset.where(relation.primary_key => pks).to_a
          end

          def multi_insert(tuples)
            pks = relation.multi_insert(tuples, return: :primary_key)
            relation.dataset.where(relation.primary_key => pks).to_a
          end
        end
        Warning.ignore(:method_redefined, false)
      end

      def self.uninstall!
        Warning.ignore(:method_redefined)
        ROM::SQL::Commands::Create.class_eval do
          def insert(tuples)
            pks = tuples.map { |tuple| relation.insert(tuple) }
            relation.where(relation.primary_key => pks).to_a
          end

          def multi_insert(tuples)
            pks = relation.multi_insert(tuples, return: :primary_key)
            relation.where(relation.primary_key => pks).to_a
          end
        end
        Warning.ignore(:method_redefined, false)
      end
    end
  end
end
