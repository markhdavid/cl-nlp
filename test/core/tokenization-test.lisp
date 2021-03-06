(in-package #:nlp.core)
(named-readtables:in-readtable rutilsx-readtable)

;;; @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;;; These tests are referenced from
;;; https://github.com/nltk/nltk/blob/develop/nltk/test/tokenize.doctest
;;; The word tokenizer tests are placed in a text file word-tests.txt under
;;; test/core. The string to be tokenized and the tokens are separated by [>>>].
;;; The tokens which are read in as a string are transformed into a list of
;;; string tokens.
;;; @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

(defvar *word-tokenization-tests*
  (dict-from-file (test-file "core/word-tests.txt")
                  :separator "[>>>]"
                  :val-transform #`(split-sequence #\Space %)))

(deftest word-tokenizer ()
  (dotable (str toks *word-tokenization-tests*)
    (should be equal toks
            (tokenize <word-tokenizer> str))))

(deftest regex-tokenizer ()
  (should be equal '("," "." "," "," "?")
          (tokenize (make 'regex-word-tokenizer :regex "[,\.\?!\"]\s*")
                    "Alas, it has not rained today. When, do you think, will it rain again?"))
  (should be equal '("<p>" "<b>" "</b>" "</p>")
          (tokenize (make 'regex-word-tokenizer :regex "</?(b|p)>")
                    "<p>Although this is <b>not</b> the case here, we must not relax our vigilance!</p>"))
  (should be equal '("las" "has" "rai" "rai")
          (tokenize (make 'regex-word-tokenizer :regex "(h|r|l)a(s|(i|n0))")
                    "Alas, it has not rained today. When, do you think, will it rain again?")))

(deftest sent-tokenizer ()
  (should be equal
          '("Good muffins cost $3.88  in New York."
            "Please buy me  two of them."
            "Thanks.")
          (tokenize <sent-splitter>
                    "Good muffins cost $3.88  in New York.   Please buy me  two of them.    Thanks.")))


;; (dolist (group (split "" (split #\Newline
;;                                 (read-file "~/prj/asu-labs/ner-uk/doc/sent-tokenization.txt"))
;;                       :test 'string= :remove-empty-subseqs t))
;;   (with ((ncore::+abbrevs-with-dot+ +uk-abbrevs+)
;;          (sents (split #\Newline (string-trim +white-chars+ (atomize group))))
;;          (rez (tokenize <sent-splitter> (strjoin #\Space sents))))
;;     (unless (equalp sents rez)
;;       (print (list sents rez))))
;;   (terpri))
