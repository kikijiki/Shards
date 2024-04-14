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
    bool isPalindrome(ListNode* head) {
        if (head == nullptr || head->next == nullptr) return true;

        ListNode *slow = head, *fast = head;
        while (fast->next != nullptr && fast->next->next != nullptr) {
            slow = slow->next;
            fast = fast->next->next;
        }
        
        auto middle = slow->next;
        ListNode *secondHalf = reverseList(middle);

        ListNode *p1 = head;
        ListNode *p2 = secondHalf;
        while (p2) {
            if (p1->val != p2->val)
                return false;
            p1 = p1->next;
            p2 = p2->next;
        }

        return true;
    }

private:
    ListNode* reverseList(ListNode* head) {
        ListNode *prev = nullptr, *next = nullptr;
        while (head != nullptr) {
            next = head->next;
            head->next = prev;
            prev = head;
            head = next;
        }
        return prev;
    }
};
