struct GraphQLRequest<Variables: Encodable>: Encodable {
  let query: String
  let variables: Variables
}
 