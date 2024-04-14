impl Solution {
    pub fn sort_colors(nums: &mut Vec<i32>) {
        let mut counts = vec![0;3];
        for x in nums.iter() {
            counts[*x as usize] += 1;
        }
        nums.clear();
        for x in 0i32..3i32 {
            for n in 0..counts[x as usize] {
                nums.push(x);
            }
        }
    }
}