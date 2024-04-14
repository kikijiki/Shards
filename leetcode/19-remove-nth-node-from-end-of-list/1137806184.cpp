/**
 * Definition for singly-linked list.
 * struct ListNode {
 *     int val;
 *     ListNode *next;
 *     ListNode() : val(0), next(nullptr) {}
 *     ListNode(int x) : val(x), next(nullptr) {}
 *     ListNode(int x, ListNode *next) : val(x), next(next) {}
 * };
 */
class Solution {
public:
    ListNode* removeNthFromEnd(ListNode* head, int n) {
        ListNode* x = head;
        
        int len = 1;
        while(x->next) {
            len++;
            x = x->next;
        }

        if(n == len) {
            ListNode* newHead = head->next;
            return newHead;
        }
        
        x = head;
        for(int i = 1; i < len - n; ++i)
            x = x->next;
        
        x->next = x->next->next;
        
        return head;
    }
};