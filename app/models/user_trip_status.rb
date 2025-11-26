class UserTripStatus < ApplicationRecord
  belongs_to :user
  belongs_to :trip
  has_one :preferences_form, dependent: :destroy

  enum role: { creator: 'creator', invitee: 'invitee' }
  # Statut de l'utilisateur dans le voyage (par ex. invité, accepté)
  # Note : devise_invitable gère le statut d'invitation sur User, mais ceci suit le lien avec le voyage.
  # Nous pouvons utiliser ceci pour la logique spécifique à l'application.
end
