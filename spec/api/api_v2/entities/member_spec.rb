describe APIv2::Entities::Member do
  let(:member) { create(:verified_member) }

  subject { OpenStruct.new APIv2::Entities::Member.represent(member).serializable_hash }

  before { Currency.stubs(:codes).returns(%w[cny btc]) }

  it { expect(subject.sn).to eq member.sn }
  it { expect(subject.name).to eq member.name }
  it { expect(subject.email).to eq member.email }
  it { expect(subject.activated).to be true }

  it 'accounts' do
    expect(subject.accounts).to match [
      { currency: 'cny', balance: '0.0', locked: '0.0', address: nil },
      { currency: 'btc', balance: '0.0', locked: '0.0', address: nil }
    ]
  end
end
