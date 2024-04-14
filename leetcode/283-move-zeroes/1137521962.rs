impl Solution {
    pub fn move_zeroes(nums: &mut Vec<i32>) {
        let mut z = 0;
        nums.retain(|x| {
           if *x == 0 {
               z += 1;
               return false;
            }
            return true;
        });
        
        for _ in 0..z {
            nums.push(0);
        }
    }
}