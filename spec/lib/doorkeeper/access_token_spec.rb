require 'spec_helper'

describe Doorkeeper::AccessToken do

  let(:app) { Doorkeeper::Application.create!(name: 'test', uid: 'foo', secret: 'bar', redirect_uri: 'http://test.host/oauth/callback') }
  let(:member) { create(:member) }

  subject! { Doorkeeper::AccessToken.create!(application_id: app.id, resource_owner_id: member.id, scopes: 'identity', expires_in: 1.week) }

  context "creation" do
    it "should generate corresponding api token" do
      lambda {
        Doorkeeper::AccessToken.create!(application_id: app.id, resource_owner_id: member.id, scopes: 'identity', expires_in: 1.week)
      }.should change(APIToken, :count).by(1)
    end

    it "should prevent app requesting all scopes" do
      lambda {
        Doorkeeper::AccessToken.create!(application_id: app.id, resource_owner_id: member.id, scopes: 'all', expires_in: 1.week)
      }.should raise_error
    end

    it "should set token" do
      expect(subject.token).to eq APIToken.last.to_oauth_token
    end

    it "should setup api token correctly" do
      api_token = APIToken.last
      expect(api_token.label).to eq app.name
      expect(api_token.scopes).to eq %w(identity)
      expect(api_token.expire_at).not_to be_nil
    end

    it "should link api token" do
      expect(APIToken.last.oauth_access_token).to eq subject
    end
  end

  context "revoke" do
    it "should revoke access token and destroy corresponding api token" do
      subject.revoke
      expect(subject).to be_revoked
      expect(APIToken.find_by_id(subject.api_token.id)).to be_nil
    end
  end

  context "deletion" do
    it "should soft delete record" do
      subject.destroy
      expect(Doorkeeper::AccessToken.find_by_id(subject.id)).to be_nil
      expect(Doorkeeper::AccessToken.with_deleted.find_by_id(subject.id)).to eq subject
    end
  end
end
