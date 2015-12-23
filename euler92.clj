;; first version

;; newbie to clojure, using poor style at the repl
;; lein repl
;(defn sumsqdigits [x] (->> (seq(str x)) (map #(* (- (int %) 48) (- (int %) 48))) (apply +) ))
;(defn until1or89 [x] (loop [v x] (if (contains? #{1 89} v) v (recur (sumsqdigits v) ))) )
;(count (filter #(= 89 %) (map until1or89 (range 1 10000))) )

;; caching version; be careful not to use a lazy seq or list
(def maxcount 10000000)
(defn square [x] (* x x))
;; sum of square of digits
(defn ssd [x] 
  (loop [s 0 x x] 
        (if (<= x 0) s 
              (recur (+ s (square (mod x 10))) (quot x 10)))))

;; build caches: sum square digits vector of integers, and booleans, for numbers 0..999
(def ssdvi (into (vector-of :int) 
                 (map ssd (range 0 1000))))
;; use cache
(defn ssd2 [x] 
  (+ (nth ssdvi (mod x 1000)) 
     (nth ssdvi (mod (quot x 1000) 1000)) 
     (nth ssdvi (quot x 1000000))))
(defn endsin89 [x] 
  (loop [v x] (if (contains? #{0 1 89} v) 
                (= 89 v) 
                (recur (nth ssdvi v) ))) )
(def ssdvb (into (vector-of :boolean) 
                 (map endsin89 (range 0 999))))
;; use the caches directly when possible
(defn euler92 [] 
    (loop [s 0 i 1] 
    (if (> i maxcount) s 
      (recur (if (nth ssdvb (ssd2 i)) 
               (inc s) 
               s) 
             (inc i)))))


(time (euler92))
;; about 1.2 seconds on this i5 laptop

(defn timeit [expr]
  (let [start (. System (nanoTime))
         ret (expr)
         finish (. System (nanoTime))]
     (print (* 1.0e-6 (- finish start)))
     (println " milliseconds")
    ret))

(timeit euler92)
