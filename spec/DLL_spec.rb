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

        it 'should be able to pop from head and tail and maintain length' do 

            a = DoublyLinkedList.new()
            a.insert_head(10)
            a.insert_tail(12)
            a.insert_head(5)
            a.insert_tail(15)
            expect(a.to_s).to eq('[5,10,12,15,]')
            expect(a.pop_head.data).to eq(5)
            expect(a.pop_tail.data).to eq(15)
            expect(a.len).to eq(2)
            expect(a.to_s).to eq('[10,12,]')
            expect(a.peek_head.data).to eq(10)
            expect(a.peek_tail.data).to eq(12)
            expect(a.to_s).to eq('[10,12,]') # should not be destructive
        end
    end
end