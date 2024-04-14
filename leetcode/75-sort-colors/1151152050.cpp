class Solution {
public:
    void sortColors(vector<int>& nums) {
        int c[] = {0,0,0};
        
        for(int x : nums){
            ++c[x];
        }
        
        int o = 0;
        for(int n = 0; n < 3; ++n)
            for(int x = 0; x < c[n]; ++x)
                nums[o++] = n;
    }
};