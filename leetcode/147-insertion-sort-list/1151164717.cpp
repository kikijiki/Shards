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
    ListNode* insertionSortList(ListNode* head) {
        if (!head || !head->next) {
            return head;
        }

        ListNode *sorted = head;
        ListNode *curr = head->next;

        while (curr) {
            if (curr->val < sorted->val) {
                sorted->next = curr->next;
                if (curr->val <= head->val) {
                    curr->next = head;
                    head = curr;
                } else {
                    ListNode *temp = head;
                    while (temp->next->val < curr->val) {
                        temp = temp->next;
                    }
                    curr->next = temp->next;
                    temp->next = curr;
                }
            } else {
                sorted = curr;
            }
            curr = sorted->next;
        }

        return head;
    }
};
