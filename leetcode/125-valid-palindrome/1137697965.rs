impl Solution {
    pub fn is_palindrome(s: String) -> bool {
        let chars = s.to_lowercase().chars().filter(|c| c.is_alphanumeric()).collect::<Vec<_>>();
        let mut reversed_chars = chars.clone();
        reversed_chars.reverse();
        
        chars == reversed_chars
    }
}