class TripBroadcaster
  def self.broadcast_update(trip)
    trip.users.each do |user|
      # Render the partial with the specific user as 'current_user'
      # We use ApplicationController.render to render outside of a controller request
      # We pass 'current_user' as a local variable which the partial uses

      html = ApplicationController.render(
        partial: 'trips/trip_card',
        locals: { trip: trip, current_user: user },
        formats: [:html]
      )

      # Broadcast to the user's private stream for the index card
      Turbo::StreamsChannel.broadcast_replace_to(
        user,
        target: ActionView::RecordIdentifier.dom_id(trip),
        html: html
      )

      # Also broadcast for the SHOW page status card
      status_html = ApplicationController.render(
        partial: 'trips/trip_status',
        locals: { trip: trip, current_user: user },
        formats: [:html]
      )

      Turbo::StreamsChannel.broadcast_replace_to(
        user,
        target: ActionView::RecordIdentifier.dom_id(trip, :status),
        html: status_html
      )
    end
  end
end
