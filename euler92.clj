;; newbie to clojure, using poor style at the repl
;; lein repl
(defn sumsqdigits [x] (->> (seq(str x)) (map #(* (- (int %) 48) (- (int %) 48))) (apply +) ))
(defn until1or89 [x] (loop [v x] (if (contains? #{1 89} v) v (recur (sumsqdigits v) ))) )
(count (filter #(= 89 %) (map until1or89 (range 1 10000000))) )
