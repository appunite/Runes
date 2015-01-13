import Quick
import Nimble
import Runes

class ArraySpec: QuickSpec {
    override func spec() {
        describe("Array") {
            describe("map") {
                // fmap id = id
                it("obeys the identity law") {
                    let array = ["fco"]
                    let lhs = id <^> array
                    let rhs = array

                    expect(lhs).to(equal(rhs))
                }

                // fmap (g . h) = (fmap g) . (fmap h)
                it("obeys the function composition law") {
                    let array = ["foo"]
                    let lhs = compose(append, prepend) <^> array
                    let rhs = compose(curry(<^>)(append), curry(<^>)(prepend))(array)

                    expect(lhs).to(equal(rhs))
                }
            }

            describe("apply") {
                // pure id <*> v = v
                it("obeys the identity law") {
                    let array = ["foo"]
                    let lhs = pure(id) <*> array
                    let rhs = array

                    expect(lhs).to(equal(rhs))
                }

                // pure f <*> pure x = pure (f x)
                it("obeys the homomorphism law") {
                    let foo = "foo"
                    let lhs: [String] = pure(append) <*> pure(foo)
                    let rhs: [String] = pure(append(foo))

                    expect(lhs).to(equal(rhs))
                }

                // u <*> pure y = pure ($ y) <*> u
                it("obeys the interchange law") {
                    let foo = "foo"
                    let lhs: [String] = pure(append) <*> pure(foo)
                    let rhs: [String] = pure({ $0(foo) }) <*> pure(append)

                    expect(lhs).to(equal(rhs))
                }

                // u <*> (v <*> w) = pure (.) <*> u <*> v <*> w
                it("obeys the composition law") {
                    let array = ["foo"]
                    let lhs = pure(append) <*> (pure(prepend) <*> array)
                    let rhs = pure(curry(compose)) <*> pure(append)  <*> pure(prepend) <*> array

                    expect(lhs).to(equal(rhs))
                }
            }

            describe("flatMap") {
                // return x >>= f = f x
                it("obeys the left identity law") {
                    let foo = "foo"
                    let lhs: [String] = pure(foo) >>- compose(append, pure)
                    let rhs: [String] = compose(append, pure)(foo)

                    expect(lhs).to(equal(rhs))
                }

                // m >>= return = m
                it("obeys the right identity law") {
                    let array = ["foo"]
                    let lhs = array >>- pure
                    let rhs = array

                    expect(lhs).to(equal(rhs))
                }

                // (m >>= f) >>= g = m >>= (\x -> f x >>= g)
                it("obeys the associativity law") {
                    let array = ["foo"]
                    let lhs = (array >>- compose(append, pure)) >>- compose(prepend, pure)
                    let rhs = array >>- { x in compose(append, pure)(x) >>- compose(prepend, pure) }

                    expect(lhs).to(equal(rhs))
                }
            }
        }
    }
}
