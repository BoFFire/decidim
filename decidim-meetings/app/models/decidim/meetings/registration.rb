# frozen_string_literal: true

module Decidim
  module Meetings
    # The data store for a Registration in the Decidim::Meetings component.
    class Registration < Meetings::ApplicationRecord
      include Decidim::DataPortability

      belongs_to :meeting, foreign_key: "decidim_meeting_id", class_name: "Decidim::Meetings::Meeting"
      belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User"
      belongs_to :user_group, foreign_key: "decidim_user_group_id", class_name: "Decidim::UserGroup", optional: true

      validates :user, uniqueness: { scope: :meeting }
      validates :code, uniqueness: { allow_blank: true, scope: :meeting }
      validates :code, presence: true, on: :create

      before_validation :generate_code, on: :create

      def self.user_collection(user)
        where(decidim_user_id: user.id)
      end

      def self.export_serializer
        Decidim::Meetings::DataPortabilityRegistrationSerializer
      end

      # Pluck all Decidim::UserGroup ID's
      def self.user_group_ids
        pluck(:decidim_user_group_id)
      end

      private

      def generate_code
        self[:code] ||= calculate_registration_code
      end

      # Calculates a unique code for the model using the class
      # provided by the configuration and scoped to the meeting.
      #
      # Returns a String.
      def calculate_registration_code
        Decidim::Meetings::Registrations.code_generator.generate(self)
      end
    end
  end
end
