library(rjags)

model_string = "
model {
  for (i in 1:100) {
    x[i] ~ dnorm(0, 1)
  }
  mu <- mean(x)
  sigma <- sd(x)
}
"

jags_model = jags.model(textConnection(model_string), data = list(), n.chains = 2)
update(jags_model, n.iter = 1000)

samples = coda.samples(jags_model, c("mu", "sigma"), n.iter = 1000)
summary(samples)
