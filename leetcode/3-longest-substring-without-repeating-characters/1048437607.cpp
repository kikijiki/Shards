class Solution {
public:
    int lengthOfLongestSubstring(string s) {
        int len = s.length();
        if(len == 0) return 0;

        int longest = 0;
        std::set<char> chars;
        int left = 0, right = 0;

        while(right < len) {
            if(!chars.contains(s[right])) {
                chars.insert(s[right]);
                longest = std::max(longest, right - left + 1);
                right++;
            } else {
                if(left + longest >= len)
                    break;
                chars.erase(s[left]);
                left++;
            }
        }
        return longest;
    }
};
