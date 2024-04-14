impl Solution {
    pub fn smallest_trimmed_numbers(nums: Vec<String>, queries: Vec<Vec<i32>>) -> Vec<i32> {
        let mut answer = Vec::new();

        for query in queries.iter() {
            let k = query[0] as usize - 1;
            let trim = query[1] as usize;

            let mut trimmed_nums: Vec<(String, usize)> = nums.iter().enumerate()
                .map(|(index, num)| (num[num.len() - trim..].to_string(), index))
                .collect();

            trimmed_nums.sort_unstable_by(|a, b| a.0.cmp(&b.0).then_with(|| a.1.cmp(&b.1)));

            answer.push(trimmed_nums[k].1 as i32);
        }

        answer
    }
}