// Definition for singly-linked list.
// #[derive(PartialEq, Eq, Clone, Debug)]
// pub struct ListNode {
//   pub val: i32,
//   pub next: Option<Box<ListNode>>
// }
// 
// impl ListNode {
//   #[inline]
//   fn new(val: i32) -> Self {
//     ListNode {
//       next: None,
//       val
//     }
//   }
// }
impl Solution {
    pub fn add_two_numbers(l1: Option<Box<ListNode>>, l2: Option<Box<ListNode>>) -> Option<Box<ListNode>> {
        let mut ret: Option<Box<ListNode>> = None;
        let mut tail = &mut ret;
        let mut rem: i32 = 0;

        let mut x1 = l1;
        let mut x2 = l2;

       while x1.is_some() || x2.is_some() || rem > 0 {
            let v1 = x1.as_ref().map_or(0, |node| node.val);
            let v2 = x2.as_ref().map_or(0, |node| node.val);

            let sum = v1 + v2 + rem;
            let val = sum % 10;
            rem = sum / 10;

            *tail = Some(Box::new(ListNode::new(val)));
            tail = &mut tail.as_mut().unwrap().next;

            x1 = x1.and_then(|node| node.next.clone());
            x2 = x2.and_then(|node| node.next.clone());
        }

        return ret;
    }
}