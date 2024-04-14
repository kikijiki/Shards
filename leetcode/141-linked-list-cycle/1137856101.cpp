/**
 * Definition for singly-linked list.
 * struct ListNode {
 *     int val;
 *     ListNode *next;
 *     ListNode(int x) : val(x), next(NULL) {}
 * };
 */
class Solution {
public:
    bool hasCycle(ListNode *head) {
        if(!head) return false;
        
        auto fast = head;
        auto slow = head;
        
        while(fast && fast->next && slow){
            fast = fast->next->next;
            slow = slow->next;
            if(fast == slow)
                return true;
        }
        
        return false;
    }
};