/**
 * Definition for a binary tree node.
 * struct TreeNode {
 *     int val;
 *     TreeNode *left;
 *     TreeNode *right;
 *     TreeNode() : val(0), left(nullptr), right(nullptr) {}
 *     TreeNode(int x) : val(x), left(nullptr), right(nullptr) {}
 *     TreeNode(int x, TreeNode *left, TreeNode *right) : val(x), left(left), right(right) {}
 * };
 */
class Solution {
    bool check(TreeNode* n, long long min, long long max){
        if(!n) return true;
        return n->val > min && n->val < max &&
            check(n->left, min, n->val) && check(n->right, n->val, max);
    }
public:
    bool isValidBST(TreeNode* root) {
        return check(root, LONG_MIN, LONG_MAX);
    }
};