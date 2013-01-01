Spree::Order.class_eval do
  checkout_flow do
    go_to_state :payment, :if => lambda { |order| order.payment_required? }
    go_to_state :confirm, :if => lambda { |order| order.confirmation_required? }
    go_to_state :complete
    remove_transition :from => :delivery, :to => :confirm
  end
end
