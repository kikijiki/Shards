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
public:
    vector<vector<int>> levelOrder(TreeNode* root) {
        if(!root) return {};
        
        auto v = vector<vector<int>>();
        auto q = vector<TreeNode*>{root};
        while(!q.empty()){
            auto& l = v.emplace_back();
            auto qs = q.size();
            for(auto i = 0; i < qs; ++i)
            {
                auto c = q[0];
                l.push_back(c->val);
                if(c->left) q.push_back(c->left);
                if(c->right) q.push_back(c->right);
                q.erase(q.begin());
            }
        }
        return v;
    }
};