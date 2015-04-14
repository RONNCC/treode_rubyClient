require './DLL'
require 'pp'

describe DoublyLinkedList do
    describe 'a DLL ' do
        it 'should be able to insert head/tails and maintain length' do 
            a = DoublyLinkedList.new()
            a.insert_head(5)
            a.insert_head(2)
            a.insert_head(-1)
            a.insert_tail(7)
            a.insert_tail(12)
            expect(a.to_s).to eq('[-1,2,5,7,12,]')
            expect(a.len).to eq(5)
        end
    end
end