(ns MinimalExampleShare
  (:require [java-time.api :as t]))

(defn first-month-of-year [year]
  (t/as (t/local-date year) :month-of-year))
