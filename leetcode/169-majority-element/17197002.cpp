class Solution {
public:
    int majorityElement(vector<int> &num) {
        std::map<int, int> m;
        int maj = num[0];
        int majn = 1;
        
        for(auto i : num)
        {
            if(m.count(i) > 0){m[i]++;}
            else{m[i] = 1;}
            if(m[i] > majn)
            {
                majn = m[i];
                maj = i;
            }
        }
        
        return maj;
    }
};