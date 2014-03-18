class Ability
  include CanCan::Ability

  def initialize(user)
    can [ :read, :index, :see_revisions_of ], Need

    if user.editor?
      can [ :create, :update, :close, :reopen, :perform_actions_on ], Need
      can :create, Note
    end

    can :descope, Need if user.admin?
  end
end
