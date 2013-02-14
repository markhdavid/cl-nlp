;;; (c) 2013 Vsevolod Dyomkin

(in-package #:nlp.generation)
(named-readtables:in-readtable rutils-readtable)


(defgeneric generate-text (generator data length &key skip-paragraphs)
  (:documentation
   "Generate random text of LENGTH words based on some DATA
    (usually, table of transition probabilities between tokens).
    Unless SKIP-PARAGRAPHS is set, the text may include newlines.
   "))


(defclass text-generator ()
  ()
  (:documentation
   "Base class for text generators."))

(defclass markov-chain-generator (text-generator)
  ((order :accessor markov-order :initarg :order))
  (:documentation
   "Markov chain generator of the given ORDER."))

(defclass mark-v-shaney-generator (markov-chain-generator)
  ((order :reader markov-order :initform 2))
  (:documentation
   "Markov chain generator of the 1st order — it is defined, because:
    - this is the general and most useful case
    - it allows to use optimized data-structures and a simpler algorithm
    - the name is well-known
   "))

(defmethod generate-text ((generator markov-chain-generator) transitions length
                          &key skip-paragraphs)
  "Generate text with a markov model of some MARKOV-ORDER described by
   table TRANSITIONS of transition probabilities between reverse prefixes
   of MARKOV-ORDER length and words.
   May not return period at the end."
  (let* ((order (markov-order generator))
         (initial-prefix (if (> order 1)
                             (cons "¶" (make-list (1- order)))
                             (list "¶")))
         (prefix initial-prefix)
         rez)
    (loop :for i :from 1 :to length :do
      (let ((r (random 1.0))
            (total 0))
        (dotable (word prob
                  (or (get# prefix transitions)
                      ;; no continuation - start anew
                      (prog1 (get# (setf prefix initial-prefix) transitions)
                        ;; add period unless one is already there
                        (unless (every #'period-char-p (car rez))
                          (push "." rez)
                          (incf i)))))
          (when (> (incf total prob) r)
            (if (string= "¶" word)
                (if skip-paragraphs
                    (decf i)  ; don't count newline if we don't include it
                    (push +newline+ rez))
                (push word rez))
            (setf prefix (cons word (butlast prefix)))
            (return)))))
    (reverse rez)))

(define-lazy-singleton mark-v-shaney (make 'markov-chain-generator :order 2)
  "The infamous Mark V. Shaney.")