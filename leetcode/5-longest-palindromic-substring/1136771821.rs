impl Solution {
    pub fn longest_palindrome(s: String) -> String {
        if s.is_empty() {
            return s;
        }

        let chars: Vec<_> = s.chars().collect();
        let len = chars.len();
        let mut max = 0;
        let mut pal = &chars[0..1];

        for start in 0..len {
            for end in (start + 1)..=len {
                let pal_len = end - start;
                if pal_len <= max {
                    continue;
                }

                let mut is_pal = true;
                for idx in start..end {
                    if chars[idx] != chars[end - 1 - (idx - start)] {
                        is_pal = false;
                        break;
                    }
                }

                if is_pal {
                    pal = &chars[start..end];
                    max = pal.len();
                }
            }
        }

        pal.iter().collect()
    }
}
