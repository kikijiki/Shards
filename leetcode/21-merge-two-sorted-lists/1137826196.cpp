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
    ListNode* mergeTwoLists(ListNode* list1, ListNode* list2) {
        if(!list1 && !list2) return nullptr;
        if(!list1) return list2;
        if(!list2) return list1;
        
        auto x = list1;
        auto y = list2;
        
        ListNode* h;
        ListNode* n;
        
       if(x->val < y->val){
            h = x;
            x = x->next;
        } else {
            h = y;
            y = y->next;
        }
        
        n = h;
        
        while(x || y){
            if(!x){
                n->next = y;
                y = y->next;
            } else if (!y){
                n->next = x;
                x = x->next;
            }else if(x->val < y->val){
                n->next = x;
                x = x->next;
            } else {
                n->next = y;
                y = y->next;
            }
            
            n = n->next;
        }
        
        return h;
    }
};