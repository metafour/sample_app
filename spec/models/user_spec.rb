require 'spec_helper'

describe User do

  before { @user = User.new name: "Example User", email: "user@example.com",
                            password: "foobar", password_confirmation: "foobar" }

  subject { @user }

  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:authenticate) }
  it { should respond_to(:admin) }
 

  it { should be_valid }
  it { should_not be_admin }

  describe "with admin attribute set to true" do
    before do
      @user.save!
      @user.toggle!(:admin)
    end

    it { should be_admin }
  end

  describe "when name is not present" do
    before { @user.name = "" }
    it { should_not be_valid }
  end

  describe "when name is too long" do
    before { @user.name = "a" * 51 }
    it { should_not be_valid }
  end

  describe "when name is too short" do
    before { @user.name = "a" * 2 }
    it { should_not be_valid }
  end

  describe "when email is not present" do
    before { @user.email = "" }
    it { should_not be_valid }
  end

  describe "when email is not valid" do
   addresses =  %w[user@host,com user_at_foo.org example.user@foo.foo@bar_baz.com foot@bar+baz.com foo@bar..com]
    addresses.each do |invalid_address|
      before { @user.email = invalid_address }
      it { should_not be_valid }
    end
  end

  describe "when email is valid" do
    addresses = %w[user@host.COM user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
    addresses.each do |valid_address|
      before { @user.email = valid_address }
      it { should be_valid }
    end
  end

  describe "when email is not unique" do
    before do
      #user2 = User.new name: "Example User 2", email: "user@example.com".downcase
      #user2.save
      user_with_same_email = @user.dup
      user_with_same_email.save
    end
    it "should not be valid" do
      expect(@user).not_to be_valid
    end
  end

  describe "email address with mixed case" do
    let(:mixed_case_email) { "Foo@ExAMPle.CoM" }

    it "should be all lowercase" do
      @user.email = mixed_case_email
      @user.save

      expect(@user.reload.email).to eq mixed_case_email.downcase
    end
  end

  describe "when password is not present" do
    before do
      @user = User.new name: "Example User", email: "user@example.com", 
                        password: " ", password_confirmation: " "
    end

    it { should_not be_valid }
  end

  describe "when password does not match confirmation" do
    before { @user.password_confirmation = "mismatch" }
    it { should_not be_valid }
  end

  describe "with a password that is too short" do
    before { @user.password = @user.password_confirmation = "a" * 5 }
    it { should_not be_valid }
  end

  describe "return value of authenticate method" do
    before { @user.save }
    let(:found_user) { User.find_by(email: @user.email) }

    describe "with valid password" do
      it { should eq found_user.authenticate(@user.password) }
    end

    describe "with invalid password" do
      let(:user_for_invalid_password) { found_user.authenticate("invalid") }

      it { should_not eq user_for_invalid_password }
      specify { expect(user_for_invalid_password).to be_false }
    end
  end

  describe "with remember token" do
    before { @user.save }

    its(:remember_token) { should_not be_blank }
  end

end
