use std::collections::HashSet;

impl Solution {
    pub fn length_of_longest_substring(s: String) -> i32 {
        let chars: Vec<char> = s.chars().collect();
        let mut set = HashSet::new();
        let mut longest = 0;
        let mut left = 0;
        let mut right = 0;

        while right < chars.len() {
            if !set.contains(&chars[right]) {
                set.insert(chars[right]);
                longest = std::cmp::max(longest, right - left + 1);
                right += 1;
            } else {
                if chars.len() - left <= longest {
                    break; // early break condition
                }
                set.remove(&chars[left]);
                left += 1;
            }
        }
        longest as i32
    }
}