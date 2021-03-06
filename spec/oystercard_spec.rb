require 'oystercard'

describe Oystercard do
  let(:penalty_fare) { 5 }
  let(:paddington) { double("Paddington") }
  let(:baker_street) { double("Baker Street")}

  it "defaults to a balance of 0" do
    expect(subject.balance).to eq(0)
  end

  it "adds money to the card balance" do 
    subject.top_up(5)
    expect(subject.balance).to eq(5)
  end

  it 'prevents you from topping up beyond the maximum balance' do
    expect { subject.top_up(subject.limit + 1) 
    }.to raise_error "You cannot top up over the limit of £#{subject.limit}"
  end

  it "has en empty list of journeys on creation" do
    expect(subject.journey_log.journeys).to be_empty
  end

  it "prevents you from touching in unless the card's balance has enough for the minimum fare" do
    expect {subject.touch_in(paddington)
    }.to raise_error "You need the minimum fare balance of £1"
  end

  context "going on a journey" do
    before do
      subject.top_up(subject.limit)
      allow(paddington).to receive(:zone).and_return(1)
      subject.touch_in(paddington)
    end

    it "deducts the minimum fee on touch out" do
      allow(baker_street).to receive(:zone).and_return(1)
      expect { subject.touch_out(baker_street) 
      }.to change{ subject.balance }.by(-1)
    end

    it "lets you touch out and end the journey" do
      allow(baker_street).to receive(:zone).and_return(1)
      subject.touch_out(baker_street)
      expect(subject.journey_log.outstanding_fare?).to eq(nil)
    end

    it "deducts the penalty fare if you touch in twice" do
      expect { subject.touch_in(baker_street) }.to change { subject.balance }.by(-penalty_fare)
    end
  end 
end
