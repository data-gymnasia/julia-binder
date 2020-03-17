using Plots
import Base.Iterators: countfrom

function SIR_simulation(population_size, infection_probability)
    statuses = fill("susceptible", population_size, 1)
    statuses[1, 1] = "infectious"
    for t in countfrom(2)
        n_infectious = sum(statuses[:, t-1] .== "infectious")
        if n_infectious == 0
            break
        end
        statuses = [statuses fill("susceptible", population_size)]
        for k in 1:population_size
            if statuses[k, t-1] == "susceptible"
                if rand() < 1 - (1 - infection_probability)^n_infectious
                    statuses[k, t] = "infectious"
                end
            else
                statuses[k, t] = "recovered"
            end
        end
    end
    statuses
end
