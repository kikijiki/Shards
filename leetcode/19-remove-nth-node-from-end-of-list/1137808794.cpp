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
        if (!head) return nullptr;

        ListNode* first = head;
        ListNode* second = head;

        for (int i = 0; i < n; ++i)
        {
            if (!first->next)
                return head->next;
            first = first->next;
        }

        while (first->next)
        {
            first = first->next;
            second = second->next;
        }

        second->next = second->next->next;

        return head;
    }
};