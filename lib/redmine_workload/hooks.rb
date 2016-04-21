module RedmineWorkload
  module Hooks
    class ViewHooks < Redmine::Hook::ViewListener
      render_on :view_my_account, partial: 'hooks/workload/view_my_account'
    end
  end
end

