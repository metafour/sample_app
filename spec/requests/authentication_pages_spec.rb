require 'spec_helper'

describe "Authentication" do

  subject { page }

  describe "signin page" do

    before { visit signin_path }

    it { should have_content('Sign in') }
    it { should have_title(full_title('Sign in')) }
  end

  describe 'signin' do

    before { visit signin_path }

    let(:submit) { 'Sign in' }

    describe 'with invalid information' do
      before { click_button submit }

      it { should have_title(full_title('Sign in')) }
      it { should have_selector('div.alert.alert-error', text: 'Invalid') }

      describe "after visiting another page" do
        before { click_link "Home" }

        it { should_not have_selector('div.alert.alert-error', text: 'Invalid') }
      end
    end

    describe 'with valid information' do
      let(:user) { FactoryGirl.create(:user) }
      before { sign_in user }
      
      #before do
      #  fill_in "Email",      with: user.email.upcase
      #  fill_in "Password",   with: user.password
      #  click_button submit
      #end

      it { should have_title(user.name) }
      it { should have_link("Users", href: users_path) }
      it { should have_link("Profile",    href: user_path(user)) }
      it { should have_link("Settings", href: edit_user_path(user)) }
      it { should have_link("Sign out",   href: signout_path) }
      it { should_not have_link("Sign in", href: signin_path) }

      describe "followed by signout" do
        before { click_link "Sign out" }
        it { should have_link("Sign in", href: signin_path) }
      end
    end

  end # end of describe 'signin'

  describe "authorization" do

    describe "for non-signed-in users" do
      let(:user) { FactoryGirl.create(:user) }

      describe "when attempting to visit a protected page" do
        before do
          visit edit_user_path(user)
          fill_in "Email", with: user.email
          fill_in "Password", with: user.password
          click_button 'Sign in'
        end
        
        describe "after signing in" do
          it "should render the desired protected page" do
            expect(page).to have_title('Edit user')
          end
        end
      end

      describe "in the Users controller" do
        
        describe "visiting the edit page" do
          before { visit edit_user_path(user) }
          it { should have_title('Sign in') }
        end

        describe "submitting to the edit page" do
          before { patch user_path(user) }
          specify { expect(response).to redirect_to(signin_path) }
        end

        describe "visiting the user index" do
          before { visit users_path }
          it { should have_title('Sign in') }
        end


      end # end of in the Users controller

    end # end of for non-signed-in users

    describe "as wrong user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com") }

      before { sign_in user, no_capybara: true }

      describe "visiting Users#edit page" do
        before { visit edit_user_path(wrong_user) }
        it { should_not have_title(full_title('Edit user')) }
      end

      describe "submitting a PATCH request to the Users#update action" do
        before { patch user_path(wrong_user) }
        specify { expect(response).to redirect_to(root_url) }
      end
    end

    describe "as non-admin user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:non_admin) { FactoryGirl.create(:user) }

      before { sign_in non_admin, no_capybara: true } # we're going to use delete

      describe "submitting a DELETE request to Users#destroy action" do
        before { delete user_path(user) }
        specify { expect(response).to redirect_to(root_url) }
      end
    end


  end # end of authorization

end # end of describe 'Authentication'