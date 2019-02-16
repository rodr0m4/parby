# Convoy

Happy little parser combinators

```
parser = Convoy.string('🚛').map { |truck| 1.step.map { |_| truck } }

parser.parse '🚛'
```

![Dad joke](https://m.media-amazon.com/images/M/MV5BODg2NzkyODc0Ml5BMl5BanBnXkFtZTcwMDMwNzEzNA@@._V1_.jpg)