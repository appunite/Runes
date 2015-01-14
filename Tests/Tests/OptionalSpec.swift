import Quick
import Nimble
import Runes

private func pureAppend(x: String) -> String? {
    return pure(append(x))
}

private func purePrepend(x: String) -> String? {
    return pure(prepend(x))
}

class OptionalSpec: QuickSpec {
    override func spec() {
        describe("Optional") {
            describe("map") {
                // fmap id = id
                it("obeys the identity law") {
                    let optional = Optional.Some("fco")
                    let lhs = id <^> optional
                    let rhs = optional

                    expect(lhs).to(equal(rhs))
                }

                // fmap (g . h) = (fmap g) . (fmap h)
                it("obeys the function composition law") {
                    let optional = Optional.Some("foo")
                    let lhs = compose(append, prepend) <^> optional
                    let rhs = compose(curry(<^>)(append), curry(<^>)(prepend))(optional)

                    expect(lhs).to(equal(rhs))
                }
            }

            describe("apply") {
                // pure id <*> v = v
                it("obeys the identity law") {
                    let optional = Optional.Some("foo")
                    let lhs = pure(id) <*> optional
                    let rhs = optional

                    expect(lhs).to(equal(rhs))
                }

                // pure f <*> pure x = pure (f x)
                it("obeys the homomorphism law") {
                    let foo = "foo"
                    let lhs: String? = pure(append) <*> pure(foo)
                    let rhs: String? = pure(append(foo))

                    expect(lhs).to(equal(rhs))
                }

                // u <*> pure y = pure ($ y) <*> u
                it("obeys the interchange law") {
                    let foo = "foo"
                    let lhs: String? = pure(append) <*> pure(foo)
                    let rhs: String? = pure({ $0(foo) }) <*> pure(append)

                    expect(lhs).to(equal(rhs))
                }

                // u <*> (v <*> w) = pure (.) <*> u <*> v <*> w
                it("obeys the composition law") {
                    let optional = Optional.Some("foo")
                    let lhs = pure(append) <*> (pure(prepend) <*> optional)
                    let rhs = pure(curry(compose)) <*> pure(append)  <*> pure(prepend) <*> optional

                    expect(lhs).to(equal(rhs))
                }
            }

            describe("flatMap") {
                // return x >>= f = f x
                it("obeys the left identity law") {
                    let foo = "foo"
                    let lhs = pure(foo) >>- pureAppend
                    let rhs = append(foo)

                    expect(lhs).to(equal(rhs))
                }

                // m >>= return = m
                it("obeys the right identity law") {
                    let optional = Optional.Some("foo")
                    let lhs = optional >>- pure
                    let rhs = optional

                    expect(lhs).to(equal(rhs))
                }

                // (m >>= f) >>= g = m >>= (\x -> f x >>= g)
                it("obeys the associativity law") {
                    let optional = Optional.Some("foo")
                    let lhs = (optional >>- pureAppend) >>- purePrepend
                    let rhs = optional >>- { x in pureAppend(x) >>- purePrepend }

                    expect(lhs).to(equal(rhs))
                }
            }
        }
    }
}
