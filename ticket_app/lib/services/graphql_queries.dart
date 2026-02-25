class GraphQLQueries {
  static const String events = r'''
    query Events($city: String, $limit: Int, $offset: Int) {
      events(city: $city, limit: $limit, offset: $offset) {
        id
        title
        price
        city
        date
        imageKey
        imageBanner
        venue
        location
        description
      }
    }
  ''';

  static const String seats = r'''
    query Seats($eventId: ID!) {
      seats(eventId: $eventId) {
        id
        eventId
        seatNumber
        rowNum
        colNum
        booked
      }
    }
  ''';

  static const String buyTickets = r'''
    mutation BuyTickets($eventId: ID!, $seatNumbers: [String!]!) {
      buyTickets(eventId: $eventId, seatNumbers: $seatNumbers) {
        message
        created
      }
    }
  ''';

  static const String myTickets = r'''
    query MyTickets {
      myTickets {
        id
        seatNumber
        purchaseDate
        event {
          id
          title
          city
          date
        }
      }
    }
  ''';
}