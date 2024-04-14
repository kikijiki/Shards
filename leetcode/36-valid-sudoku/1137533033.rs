use std::collections::HashSet;

impl Solution {
    pub fn is_valid_sudoku(board: Vec<Vec<char>>) -> bool {
        let len = board.len();
        
        let mut h = HashSet::new();
        let mut n = 0;
        
        for x in 0..len {
            
            h.clear();
            n = 0;
            for y in 0..len {
                let c = board[x][y];
                if c != '.' {
                    h.insert(c);
                    n += 1;
                }
            }
            if h.len() != n {
                return false;
            }
            
            h.clear();
            n = 0;
            for y in 0..len {
                let c = board[y][x];
                if c != '.' {
                    h.insert(c);
                    n += 1;
                }
            }
            if h.len() != n {
                return false;
            }
            
            h.clear();
            n = 0;
            
            let sx = x%3*3;
            let sy = x/3*3;
            for qx in sx..sx+3 {
                for qy in sy..sy+3 {
                    let c = board[qx][qy];
                    if c != '.' {
                        h.insert(c);
                        n += 1;
                    }
                }
            }
            
            if h.len() != n {
                return false;
            }
        }
        
        return true;
    }
}