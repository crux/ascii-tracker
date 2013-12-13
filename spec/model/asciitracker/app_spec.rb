require 'spec_helper'

include AsciiTracker 

describe AsciiTracker::App do
  subject { should be_kind_of(Class) }

  context 'with app instance' do
    let(:app) { AsciiTracker::App.new }
    it 'scans a single file' do 
      app.should_receive(:scan_file).with('a')
      app.scan(['a'])
    end
    it 'scans list of files' do 
      app.should_receive(:scan_file).with('a')
      app.should_receive(:scan_file).with('b')
      app.should_receive(:scan_file).with('c')
      app.scan(['a,b,c'])
    end

    pending 'include selector on groups'
  end
end
